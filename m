From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 08 Jul 2004 12:21:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED748F.8000700@nortelnetworks.com>
References: <1525.1089275651@www62.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael T Kerrisk <mtk-lists@gmx.net>
In-Reply-To: <1525.1089275651@www62.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael T Kerrisk wrote:

> MSG_DONTWAIT should also work with recvmsg().

Hmm...  Just tried it with a DGRAM socket, and it seems to work.  Any ideas why 
its not in the man pages?

Chris
