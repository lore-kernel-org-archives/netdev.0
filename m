From: Linda Walsh <lkml-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 33102] New: File's copied from client->linux server only copy 1st 64K data; rest is lost
Date: Mon, 11 Apr 2011 15:41:31 -0700
Message-ID: <4DA3839B.1050102@tlinx.org>
References: <bug-33102-10286@https.bugzilla.kernel.org/> <20110411152431.a5997005.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110411152431.a5997005.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org





Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Mon, 11 Apr 2011 22:12:41 GMT
> bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>
>   
>> https://bugzilla.kernel.org/show_bug.cgi?id=33102
>>
>>            Summary: File's copied from client->linux server only copy 1st
>>                     64K data;rest is lost
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.38.2
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: blocking
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
>>         ReportedBy: lkml-gT3AUAsYRbTYtjvyW6yDsg@public.gmane.org
>>         Regression: Yes
>>     
>
> Seems to be a 2.6.37->2.6.38 regression.
>
> ----------

Not exactly -- Please note -- I tried both 2.6.38(.0) and 2.6.38.1.

They both work.
