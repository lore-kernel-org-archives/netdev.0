From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM][2.4] export try_atm_clip_ops not atm_clip_ops_mutex
Date: Wed, 30 Jul 2003 10:32:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307301435.h6UEZDsG010062@ginger.cmf.nrl.navy.mil>
References: <20030730102437.B3901@infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-reply-to: Your message of "Wed, 30 Jul 2003 10:24:37 BST."
             <20030730102437.B3901@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030730102437.B3901@infradead.org>,Christoph Hellwig writes:
>On Tue, Jul 29, 2003 at 10:33:27PM -0700, David S. Miller wrote:
>> On Tue, 29 Jul 2003 13:57:05 -0400
>> chas williams <chas@cmf.nrl.navy.mil> wrote:
>> 
>> > please apply to 2.4 -- thanks
>> > 
>> > [atm]: export try_atm_clip_ops not atm_clip_ops_mutex
>> 
>> Applied, will go into 2.4.23-preX
>
>Hmm, this looks like a fix for modular compilation and should
>probably go into 2.4.22..

i would prefer it to be applied to 2.4.22 but if it cant be done
it cant be done.  i am not pressed.
