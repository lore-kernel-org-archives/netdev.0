From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: how to get per-socket stats on udp rx buffer overflow?
Date: Thu, 23 May 2002 14:15:47 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CED31D3.B5892DF4@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Is there any way for me to see how many incoming packets were dropped on a udp
socket due to overflowing the input buffer?  I specifically want this
information on a per-socket basis.

Thanks,

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
