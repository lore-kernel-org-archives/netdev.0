From: Park Lee <parklee_sel@yahoo.com>
Subject: Issue on ip_route_output_key() and ip_route_output_flow()
Date: Fri, 31 Dec 2004 07:23:19 -0800 (PST)
Message-ID: <20041231152319.46687.qmail@web51507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Linus.Torvalds@helsinki.fi,
	gw4pts@gw4pts.ampr.org, bir7@leland.Stanford.Edu,
	kuznet@ms2.inr.ac.ru, waltje@uWalt.NL.Mugnet.ORG
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262107AbULaPXX@vger.kernel.org>
To: netdev@oss.sgi.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  In /usr/src/linux/net/ipv4/route.c, there are two
functions, one is ip_route_output_key(), the other is
ip_route_output_flow(). Would you please tell me what
circumstances those two function are used for? and
What the difference between the two functions is? 
  As for ip_route_output_key() here, what is the
meaning of the "_key" in its name?

  Thank you.


=====
Best Regards,
Park Lee


		
__________________________________ 
Do you Yahoo!? 
All your favorites on one personal page – Try My Yahoo!
http://my.yahoo.com 
