From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 11:37:25 -0400
Message-ID: <1114184245.7978.5.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <17001.4034.250460.397016@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Greg Banks <gnb@sgi.com>,
        Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17001.4034.250460.397016@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 16:52 +0200, Robert Olsson wrote:

>  
>   BTW We talked with Intel folks about leaving irq disabled when reading
>   ISR and some status bit were. 

You caught me just before i said this ;-> 
Now - if those intel folks listened they would be making a killing with
their NICs on Linux. They have a paper at OLS to talk about how they get
influenced by the Linux people on how to improve their hardware - so
maybe they took the advice;-> Jesse?

Note, this would entirely solve what Andi and the SGI people are talking
about.

cheers,
jamal
