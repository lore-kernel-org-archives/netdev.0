From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device disabled.
Date: Wed, 10 Nov 2004 00:43:53 +0100
Message-ID: <20041109234353.GA6020@electric-eye.fr.zoreil.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com> <20041020121520.GA4004@electric-eye.fr.zoreil.com> <1098282567.6631.10.camel@ukabzc383.uk.saic.com> <20041020201010.GA13023@electric-eye.fr.zoreil.com> <1098350743.15528.40.camel@ukabzc383.uk.saic.com> <20041021120208.GA752@electric-eye.fr.zoreil.com> <1098437493.5513.8.camel@ukabzc383.uk.saic.com> <20041022105224.GA26714@electric-eye.fr.zoreil.com> <1099922587.16833.2.camel@ukabzc383.uk.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Content-Disposition: inline
In-Reply-To: <1099922587.16833.2.camel@ukabzc383.uk.saic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eamonn Hamilton <EAMONN.HAMILTON@saic.com> :
[...]
> Anyway, The device was brought back to functioning order by removing the
> module and re-inserting it. I have to confess, I forgot to try simply
> downing/upping it, I'll ask my friend to try that should it happen
> again. Bizarrely, the frequency of it happening seems to be down for
> whatever reason - it took ~12GB traffic to cause it to happen this
> afternoon.
> 
> Anyway, hope this helps.

Yes. It suggests that it should not be too hard to add a hack for recovery.

I am a bit surprized with this isolated report though.

--
Ueimor
