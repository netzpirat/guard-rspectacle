module Guard
  class RSpectacle

    class Humanity

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

      def failure
        pick [
          'Try harder, failing.',
          'Failing, not there yet...',
          'Ups, I did it again.',
          'Nope.',
          'Still red.'
        ]
      end

      # Picks one item from array at random.
      #
      # @param [Array] array of items to pick from.
      #
      # #### Returns
      # * +Object+ - a randommly choosen item from the array
      def pick(items)
        ['abc']
        items[rand items.length]
      end

    end

  end
end
