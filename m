From: Tim Hockin <thockin@sun.com>
Subject: Re: PATCH idea - netlink and link changes
Date: Mon, 14 Oct 2002 11:07:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB07F9.1090802@sun.com>
References: <Pine.GSO.4.30.0210120909450.23509-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <srompf@isg.de>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Sat, 12 Oct 2002, Stefan Rompf wrote:
> 
> 
>>IMHO we should merge the patches, taking your one workqueue per device
>>approach and my usage of IFF_RUNNING as a mirror bit. What do other
>>netdev people think?
>>
> Only one work queue please, not one per device.

What of two devices that lose link at the same time?  Say a hub or 
switch dies..


-- 
Tim Hockin
Systems Software Engineer
Sun Microsystems, Linux Kernel Engineering
thockin@sun.com
