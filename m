From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [horizon] avoid warning about limited range of data type
Date: Thu, 22 Jan 2004 07:52:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401221252.i0MCqSRr006824@ginger.cmf.nrl.navy.mil>
References: <20040121221531.10e4f8a2.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, rddunlap@osdl.org, venza@libero.it
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Wed, 21 Jan 2004 22:15:31 PST."
             <20040121221531.10e4f8a2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sorry i wasnt clear about that.  the same patch applies to
2.4 and 2.6 without a problem.  so if you would be so kind
as to patch 2.4 as well.

thanks

In message <20040121221531.10e4f8a2.davem@redhat.com>,"David S. Miller" writes:
>On Tue, 20 Jan 2004 20:24:37 -0500
>chas williams (contractor) <chas@cmf.nrl.navy.mil> wrote:
>
>> this patch fixes the horizon driver so that it will compile
>> without a warning.
>
>Applied, I assumed this was meant for 2.6.x only.
>
>Thanks.
>
