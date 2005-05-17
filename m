From: raz ben jehuda <razb@bitband.com>
Subject: tg3 crashes in scatter gather mode
Date: Tue, 17 May 2005 09:39:08 +0300
Message-ID: <1116311948.3021.7.camel@raz-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello. 
I have written a fast udp stack that implements a real scatter gather
over user space pages. When i use it over an Intel e1000 card every
thing works fine.  doing the same thing over the tg3 crashes the system
somewhere in tg3_poll area. 
Anyone ?
-- 
Raz
Long Live The Penguin
