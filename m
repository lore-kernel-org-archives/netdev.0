From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: simple networking clenaup questions
Date: Tue, 25 Jun 2002 15:57:16 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206251556150.13531-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi list,

i have a some uestions about networking cleanups:

1) is moving the ifmap struct into net_device still on the todo list?
	(it is according to the comments in the header file)
2) what about getting rid of dev->set_config, and just pass SIOCSIFMAP
	to the device?

thanks,

	tm

-- 
"They that can give up liberty to obtain a little temporary safety
 deserve neighter liberty nor safety" - Benjamin Franklin
