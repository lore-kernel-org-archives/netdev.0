From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: is it expected behaviour to receive one's own broadcast messages?
Date: Mon, 16 Jun 2003 17:00:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE2FD4.6060207@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have an app that is sending out broadcast messages to the local network using 
255.255.255.255.  It is registered for INADDR_ANY.  The thing that seems strange 
is that it receives a copy of every packet that it sends out.  Is this expected?

The kernel is 2.4.18.

Thanks,

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: 
cfriesen@nortelnetworks.comnetdev@oss.sgi.comnetdev@oss.sgi.com
