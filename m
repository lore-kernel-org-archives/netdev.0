From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Fri, 15 Oct 2004 14:07:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9625752b04101514073f6dab24@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <9625752b041013091772e26739@mail.gmail.com>
	 <9625752b04101309182a96fbd2@mail.gmail.com>
	 <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
	 <20041013181840.GA30852@electric-eye.fr.zoreil.com>
	 <9625752b04101313417be4cf90@mail.gmail.com>
	 <20041013205433.GC30761@electric-eye.fr.zoreil.com>
	 <9625752b04101314595f72f84a@mail.gmail.com>
	 <9625752b04101415043a078b93@mail.gmail.com>
	 <20041015161818.GA2577@electric-eye.fr.zoreil.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20041015161818.GA2577@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004 18:18:18 +0200, Francois Romieu wrote:
> May be try this one first:
> 
> http://www.uwsg.indiana.edu/hypermail/linux/kernel/0410.1/1920.html

Thanks, that appears to have fixed it.  I'm not getting an oops any
more.  I wish I hadn't assumed so much in my subject line, perhaps
someone would have found the solution before John Flinchbaugh even
reported his problem.

Also posting the oops directly instead of linking to it probably
allows people passing by to look at the oops, increasing the total
number of eyes.

I have a quick question though, if I'm using the kernel with all the
debug features turned on, should I still run it through ksymoops?
