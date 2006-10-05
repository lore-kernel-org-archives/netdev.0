From: Jingping Lin <jplin_99@yahoo.com>
Subject: socket/IP on Linux
Date: Thu, 5 Oct 2006 14:17:07 -0700 (PDT)
Message-ID: <20061005211707.61196.qmail@web30514.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web30514.mail.mud.yahoo.com ([68.142.201.242]:6832 "HELO
	web30514.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751375AbWJEVRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:17:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Linux Kernel:
For a project I will work on for mobile, I am looking
into the IP stacks on Linux.

I have a few questions to bother you:

1. is "socket.c" the file handling the socket
interface?

2. which function is for opening a socket?
It looks like "sock_map_fd()" is the one for
opening/creating a socket? Is that correct?
The "Linux IP Stacks Commentary" book suggested the
function is "int socket()" which I didn't find in
"socket.c" though.

3. Do you have documentations discussing in details
the implemented socket interfaces?

Thanks a lot in advance for your help,
Jingping


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
