From: cranium2003 <cranium2003@yahoo.com>
Subject: SNAT help
Date: Mon, 9 May 2005 01:31:13 -0700 (PDT)
Message-ID: <20050509083113.42571.qmail@web41414.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
         I want to execute my code at
NF_IP_POST_ROUTING. For that First i want to know
which functions are executing at NF_IP_POST_ROUTING
Hook. Then i have enabled SNAT and I have wrriten code
at NF_IP_POST_ROUTING but i want to get outgoing
packets' IP address as new one SNAT'ed IP address not
the one that is before SNAT? How can i do that?
         I observe that my code and SNAT are executing
at same HOOK NF_IP_POST_ROUTING. But my code is
executed first and then SNAT is doen but how to
reverse that?
regards,
cranium


		
Yahoo! Mail
Stay connected, organized, and protected. Take the tour:
http://tour.mail.yahoo.com/mailtour.html
