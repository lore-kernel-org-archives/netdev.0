From: Srinivasa Rao Katta <skatta@telegea.com>
Subject: Hi
Date: Thu, 16 May 2002 12:46:26 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CE3E262.2AA7AEA6@telegea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

How are you ?.

I have installed Redhat-7.2 on the Dell server.

It was running fine.

I am trying to set my nic card to 100MB full-duplex.

But,It was not succeeded.

Here is the my nic card info.

3Com Corporation 3c905C-TX [Fast Etherlink]

Here is my /etc/modules.conf info.
------------------------------------
# cat /etc/modules.conf
alias parport_lowlevel parport_pc
alias eth0 3c59x
alias scsi_hostadapter aic7xxx
alias sound-slot-0 i810_audio
post-install sound-slot-0 /bin/aumix-minimal -f /etc/.aumixrc -L
>/dev/null 2>&1 || :
pre-remove sound-slot-0 /bin/aumix-minimal -f /etc/.aumixrc -S
>/dev/null 2>&1 || :
alias usb-controller usb-uhci
--------------------------------------

Please advice me,How can I set my nic card for 100mb fullduplex.


Thanks,
Srinivas.
