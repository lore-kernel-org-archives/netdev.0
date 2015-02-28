From: Nicholas Krause <xerofoify@gmail.com>
Subject: Re: i40e: crash on NMI by continuous module reload
Date: Fri, 27 Feb 2015 21:11:07 -0500
Message-ID: <D7E7829A-2692-4CDE-9CE0-45812E9453A7@gmail.com>
References: <54F07630.1010802@kpanic.de> <54F078DF.5020100@gmail.com>
	<54F07C29.8010805@kpanic.de> <54F082C8.8040407@gmail.com>
	<FC41C24E35F18A40888AACA1A36F3E418ADF339C@fmsmsx115.amr.corp.intel.com>
	<3DA4D8F9-C0E0-41B9-8F9C-BD17BC7A09B3@gmail.com>
	<1425084358.9477.76.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Stefan Assmann <sassmann@kpanic.de>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1425084358.9477.76.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On February 27, 2015 7:45:58 PM EST, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>On Fri, 2015-02-27 at 16:25 -0500, Nicholas Krause wrote:
>> Thanks Shannon, 
>> For the advice on there being a newer driver and firmware to test
>that
>> on before reporting the bug against this driver. I am curious as to
>> why this newer code is not up streamed to Linux next yet through.
>
>Because I still have ~40 patches in my queue for i40e that need to go
>upstream to get the upstream driver in sync with our out-of-tree
>driver.
>
>Also Nick, please do not take advantage of me being nice to you and
>letting you remain on e1000-devel mailing list, even though you have
>been banned on @vger.kernel.org mailing lists.  It is clear from your
>attempts to help Stefan, you do not know the driver and your "blind
>stabs in the dark" to assist, only hinder our abilities to assist
>others.
Jeff, 
These seem to be the most likely culprits after reading the code. However there seems to be something else going wrong with the function call in the trace code. Jeff I do understand your busy with the upstream merging of the Intel drivers and was just wondering when the merge would be finished. Furthermore I can
try tracing this later during my March 
Break. I do appreciate you being nice to me and am sorry about making you lose
your patience. I am interested in learning about the Intel network drivers and working with them, if would like to give me something to start with. 
Sorry, 
Nick :( 


-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
