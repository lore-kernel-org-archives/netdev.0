From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Thu, 16 Sep 2004 20:52:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414A3562.2090803@pobox.com>
References: <005001c49c50$c06b9810$a010100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <005001c49c50$c06b9810$a010100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Jeff,
> We tried it out with 2.6.7. Can you pls specify the kernel version
> on which you tried and we will send a patch which works for that version.
> We will also send a more detailed description of the changes along with
> that.


Always diff against the latest version of the kernel.  You can find out 
the latest version by going to http://www.kernel.org/  You'll typically 
want the latest snapshot (preferably), or the latest pre-patch.

Standard patch submission format is described at 
http://linux.yyz.us/patch-format.html and in 
Documentation/SubmittingPatches.

When submitting a series of patches, it is normal patches to depend on 
preceding patches.

	Jeff
