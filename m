From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: RE: ok, which wise guy did this?
Date: Wed, 22 Jan 2003 11:19:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7BFCE5F1EF28D64198522688F5449D5AC6336E@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "jamal" <hadi@cyberus.ca>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Didn't the same thing happen in the 2.2 -> 2.4
transition? I believe it was for all PCI devices.
And I thought there was a boot arg something
like pci=reverse.  Does it still exist?

larry

-----Original Message-----
From: jamal [mailto:hadi@cyberus.ca]
Sent: Wednesday, January 22, 2003 6:48 AM
To: netdev@oss.sgi.com
Cc: linux-kernel@vger.kernel.org
Subject: ok, which wise guy did this?



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
