From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Wed, 13 Nov 2013 15:13:01 -0500 (EST)
Message-ID: <20131113.151301.100218641838867631.davem@davemloft.net>
References: <CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
	<20131112.181629.742226266240112179.davem@davemloft.net>
	<CAMuHMdXyqOATvE8e=3Ed17bwiDRE8w=B=xKuYwd5qorxqA0BJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXyqOATvE8e=3Ed17bwiDRE8w=B=xKuYwd5qorxqA0BJg@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 13 Nov 2013 09:54:18 +0100

> On Wed, Nov 13, 2013 at 12:16 AM, David Miller <davem@davemloft.net> wrote:
>>>> And remember about checkpatch.pl which was hardly content with the patch.
>>>
>>> Only because checkpatch looks at the _new_ lines, and doesn't compare the
>>> styles of the old and new lines.
>>
>> You really should fix the line you are changing to use tabs, please respin
>> with this in mind, thanks.
> 
> As that would add more to the TAB/space mess^H^H^Hix, I prepended a
> patch to fix all whitespace errors.

I implicitly asked you not to do this, now things are more difficult
and your original change will take longer to integrate.

Becuase now it isn't a patch set I can easily just apply quickly in
the current merge window, and it's therefore a series you'll have to
resubmit later when the merge window closes and the net-next tree
opens up again.

Sorry.
