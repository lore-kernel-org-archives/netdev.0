From: "Claus Rosenberger" <Claus.Rosenberger@rocnet.de>
Subject: vortex
Date: Tue, 28 May 2002 21:24:20 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <4416.192.168.100.10.1022613860.squirrel@deathstar.rocnet.de>
Reply-To: Claus.Rosenberger@rocnet.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi,

i have to 3c59x cards staticly linked into the kernel and now want to load
them in specific order. how to do ?
i tried "ether=irq,io,eth0 ether=irq,io,eth1" but no success. how i can
change the order to load the cards ?
thanks
