From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Thu, 19 Apr 2012 13:47:18 -0400 (EDT)
Message-ID: <20120419.134718.1020535231461282160.davem@davemloft.net>
References: <20120417195716.GA26750@merkur.ravnborg.org>
	<20120417.164400.89608576188768018.davem@davemloft.net>
	<20120419152937.GA1120@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: sam@ravnborg.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20120419152937.GA1120@merkur.ravnborg.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 19 Apr 2012 17:29:37 +0200

>> 
>> >> +	select HAVE_BPF_JIT
>> > If we sorted this block of select then the chances
>> > for merge conflict would be smaller.
>> > But this is not this patch to do so.
>> 
>> I also think we should create an arch/sparc/Kbuild for sparc
>> too, just like x86 has.
> 
> I will look into both issues.
> But only after the merge window to avoid conflicts.

Thanks a lot Sam.
