From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device disabled.
Date: Fri, 22 Oct 2004 12:52:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022105224.GA26714@electric-eye.fr.zoreil.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com> <20041020121520.GA4004@electric-eye.fr.zoreil.com> <1098282567.6631.10.camel@ukabzc383.uk.saic.com> <20041020201010.GA13023@electric-eye.fr.zoreil.com> <1098350743.15528.40.camel@ukabzc383.uk.saic.com> <20041021120208.GA752@electric-eye.fr.zoreil.com> <1098437493.5513.8.camel@ukabzc383.uk.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Content-Disposition: inline
In-Reply-To: <1098437493.5513.8.camel@ukabzc383.uk.saic.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eamonn Hamilton <EAMONN.HAMILTON@saic.com> :
[...]
> Testing the kernel with the error reset disabled just causes networking
> to stop, with no reported error after copying data from the box for a
> bit ( < 1GB )

At this point, can you have network traffic again is the device goes
through closed/open or the module through rmmod/insmod ?

> Hope this helps,

Yes.

--
Ueimor
