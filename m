From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 08 Jul 2004 10:25:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED8399.2040907@us.ibm.com>
References: <1525.1089275651@www62.gmx.net> <40ED748F.8000700@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael T Kerrisk <mtk-lists@gmx.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <40ED748F.8000700@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> Michael T Kerrisk wrote:
> 
>> MSG_DONTWAIT should also work with recvmsg().
> 
> 
> Hmm...  Just tried it with a DGRAM socket, and it seems to work.  Any 
> ideas why its not in the man pages?

Think you are on an older version of the man pages.
It's been there for a while.

thanks,
Nivedita
