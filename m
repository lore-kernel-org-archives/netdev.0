From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 14:59:06 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <9625752b04101314595f72f84a@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <9625752b041013091772e26739@mail.gmail.com>
	 <9625752b04101309182a96fbd2@mail.gmail.com>
	 <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
	 <20041013181840.GA30852@electric-eye.fr.zoreil.com>
	 <9625752b04101313417be4cf90@mail.gmail.com>
	 <20041013205433.GC30761@electric-eye.fr.zoreil.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269866AbUJMV7a@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20041013205433.GC30761@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2004 22:54:33 +0200, Francois Romieu wrote:
> [snip]
> Possible :o)
> 
> OTOH, I do not want to miss an error report.

Well the options I tried disabling (ACPI, PREEMPT) didn't stop the oops.

> [snip]
> I am not a reiserfs addict but you can imho go for the complete serie
> of reiserfs patches once you have sucked the first one (3Mo, yuck).
> 
> If you have issues with the ordering of the patches, just grep the
> patches in the 'series' file.

Ok thanks, I have work to do right now so I'll have to try this out tonight.
