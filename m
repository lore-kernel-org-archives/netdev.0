From: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device
	disabled.
Date: Mon, 08 Nov 2004 14:03:06 +0000
Message-ID: <1099922587.16833.2.camel@ukabzc383.uk.saic.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com>
	 <20041020121520.GA4004@electric-eye.fr.zoreil.com>
	 <1098282567.6631.10.camel@ukabzc383.uk.saic.com>
	 <20041020201010.GA13023@electric-eye.fr.zoreil.com>
	 <1098350743.15528.40.camel@ukabzc383.uk.saic.com>
	 <20041021120208.GA752@electric-eye.fr.zoreil.com>
	 <1098437493.5513.8.camel@ukabzc383.uk.saic.com>
	 <20041022105224.GA26714@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eamonn Hamilton <eamonn.hamilton@saic.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041022105224.GA26714@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Francois.

Sorry for the delay in getting back to you - real life has a nasty habit
of intruding :(

Anyway, The device was brought back to functioning order by removing the
module and re-inserting it. I have to confess, I forgot to try simply
downing/upping it, I'll ask my friend to try that should it happen
again. Bizarrely, the frequency of it happening seems to be down for
whatever reason - it took ~12GB traffic to cause it to happen this
afternoon.

Anyway, hope this helps.

Cheers,
Eamonn


On Fri, 2004-10-22 at 12:52 +0200, Francois Romieu wrote:
> Eamonn Hamilton <EAMONN.HAMILTON@saic.com> :
> [...]
> > Testing the kernel with the error reset disabled just causes networking
> > to stop, with no reported error after copying data from the box for a
> > bit ( < 1GB )
> 
> At this point, can you have network traffic again is the device goes
> through closed/open or the module through rmmod/insmod ?
> 
> > Hope this helps,
> 
> Yes.
> 
> --
> Ueimor
-- 
Eamonn Hamilton

Senior Systems Engineer
SAIC Ltd
Tel : 01224 333833
