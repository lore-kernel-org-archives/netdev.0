From: Metuki Sabhe <sabhe.metuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: bridge: mac addresses question (for bluetooth pan-nap)
Date: Sun, 24 Jan 2010 17:18:36 +0200
Message-ID: <549992e51001240718l19528937j7e2cb166a3b2bd2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I have a single bridge with up to 7 virtual TAP ports,
which are being added and removed dynamically.

Can I use the same MAC address for all ports and for the bridge ?
(I don't use STP as the topology is very very simple).

This is needed to allow macaddress header compression of BNEP...
(i plan to use the radio BDADDR as the MAC address for all TAP ports
and for the bridge)

thank you,
sabhe
