From: Abhinav Gupta <gupta@cpsc.ucalgary.ca>
Subject: Accessing time
Date: Thu, 25 Mar 2004 12:41:04 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <406335D0.2090308@cs.ucalgary.ca>
Reply-To: gupta@cpsc.ucalgary.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can anyone please give me pointers to accessing system time? I need to 
timestamp each tcp-packet that I receive over the network. I have tried 
using sys_gettimeoftheday() but due to frequent calls, the function 
doesn't always return a correct return value.

Thanks in advance.

Abhinav.

