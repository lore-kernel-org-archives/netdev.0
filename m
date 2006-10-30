From: dragoran <dragoran@feuerpokemon.de>
Subject: ipw3945?
Date: Mon, 30 Oct 2006 19:53:32 +0100
Message-ID: <45464A2C.5090402@feuerpokemon.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030582AbWJ3Sxc@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ipw3945 driver has been out for a while and is not yet upstream.
It requires a binary only daemon to work, but I still see no reason not 
to merge it.
Many wlan drivers require binary firmware anyway, so I don't see a 
reason not to merge it.
I also have read this: http://lwn.net/Articles/205988/ (and the old 
thread on lkml/netdev)
Can this be used to make the driver work without the daemon?
It seems that the development of the driver has stopped since july, 
maybe because it never will get merged and intel decided to stop working 
on it?
If this is true it could mean that feature intel wlan chips will end up 
with no linux drivers :(
