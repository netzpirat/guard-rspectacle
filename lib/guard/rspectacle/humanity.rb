module Guard
  class RSpectacle

    # The humanity class helps to bring some randomness
    # into the so boring and static messages from rspectacle.
    #
    class Humanity
      class << self

        # Picks a random success message.
        #
        # @return [String] a success message
        #
        def success
          pick [
                   'How cool, all works!',
                   'Awesome, all passing!',
                   'Well done, mate!',
                   'You rock!',
                   'Good job!',
                   'Yep!'
               ]
        end

        # Picks a random failure message.
        #
        # @return [String] a failure message
        #
        def failure
          pick [
                   'Try harder, failing.',
                   'Failing, not there yet...',
                   'Ups, I did it again.',
                   'Nope.',
                   'Still red.'
               ]
        end

        private

        # Picks one item from array at random.
        #
        # @param [Array] array of items to pick from.
        # @return [Object] a randomly chosen item from the array
        #
        def pick(items)
          items[rand items.length]
        end

      end

    end
  end
end
