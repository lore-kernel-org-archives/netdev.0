From: S P <speattle@yahoo.com>
Subject: [PATCH] linux 2.6.x.x  - include/net/neighbour.h spell-check
Date: Mon, 13 Sep 2004 10:48:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913174842.96183.qmail@web90003.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

in linux 2.6.x.x kernel's include/net/neighbour.h
'Neighbour' and 'Neighbor' are used interchangeably.

neighbour is british variation of neighbor, so i'd say
neighbor is more appropriate.  but then the header's
named neighbour.  

just cleaning up some in-line documentations while
reading through.

I hope my reporting format is correct!

Thanks in advance.


diff neighbour.h ../linus-2.6/include/net/neighbou
17c17
<  *    Neighbour Cache Entry Flags
---
>  *    Neighbor Cache Entry Flags
24c24
<  *    Neighbour Cache Entry States.
---
>  *    Neighbor Cache Entry States.



		
_______________________________
Do you Yahoo!?
Shop for Back-to-School deals on Yahoo! Shopping.
http://shopping.yahoo.com/backtoschool
