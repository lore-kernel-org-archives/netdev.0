From: Christopher Chan <cchan@outblaze.com>
Subject: dst cache overflow errors
Date: Sat, 03 Jul 2004 19:32:00 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E69930.1080402@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Recently, the Intel chaps wanted to have NAPI permanently enabled for 
their e100 driver. However, i still get network connectivity problems if 
I enable NAPI in e100 for 2.6.7. Severe cases result in the kernel not 
logging clear messages about its bug traps...due to the messages being 
obfuscated beyond understanding.

I wonder then whether the cause/problem, that makes the kernel log dst 
cache overflows and its BUG_TRAPs in the logs, has been identified?

Thanks,

Christopher
