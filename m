From: Dave Hansen <haveblue@us.ibm.com>
Subject: Attempt to release TCP socket errors in 2.5.41
Date: Tue, 08 Oct 2002 09:31:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA3087B.5080704@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been running a certain large webserver benchmark on an 8-way 
Profusion-based PIII Xeon.  I'm using Apache2.  These errors have 
cropped up pretty recently, definitely since 2.5.34:
Attempt to release TCP socket in state 1 f1e3f440

-- 
Dave Hansen
haveblue@us.ibm.com
