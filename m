From: jamal <hadi@cyberus.ca>
Subject: ok, which wise guy did this?
Date: Wed, 22 Jan 2003 06:47:35 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030122064047.D41405@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I just booted my spanking new P4 HT PC last night using 2.5.58
and to my dissapointment the enumeration of the ethx devices is
reversed. I have 5 ethernet ports on this; eth0-4 on 2.4.x are now listed
as eth4-0. This is rude.
I immediately pointed a finger at monsieur J Garzik (thinking ethernet,
PCI enumeration hmm) but he has denied any responsibility ;-> ;-> He
thinks it may be the sysfs people.
Can anyone give justification for this? Regardless of justification
can we have some form of backward compatibility flag?

cheers,
jamal
