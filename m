From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [lec] put back pressure on network stack
Date: Thu, 26 Feb 2004 15:12:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402262012.i1QKCHg5021427@ginger.cmf.nrl.navy.mil>
References: <davem@redhat.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Thu, 26 Feb 2004 12:10:36 PST." <20040226121036.7472a38a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i probably managed to combine two patches again.  i will get it
sorted out.

In message <20040226121036.7472a38a.davem@redhat.com>,"David S. Miller" writes:
>This conflicts with a previous patch you sent me in this group entitled:
>
>[ATM]: [lec] send queued packets immediately after path switch
>
>So it fully rejected when I tried to apply this one, it looks to me
>like the changes this is trying to add are already in there as a result
>of the previous change.
>
