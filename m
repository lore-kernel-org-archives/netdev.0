From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] minor cleanups for 2.5
Date: Mon, 21 Jul 2003 11:03:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307211506.h6LF63sG012139@ginger.cmf.nrl.navy.mil>
References: <20030721052416.3ef97f3b.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Mon, 21 Jul 2003 05:24:16 PDT."
             <20030721052416.3ef97f3b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030721052416.3ef97f3b.davem@redhat.com>,"David S. Miller" writes:
>> (and how does __inline__ work
>> when its the timer function?)
>
>If you take the address of a function marked inline,
>gcc outputs a non-inline of the function.

i figured that.  tagging this function inline is essentially
pointless.  (which was sort of my point in a roundabout way)
