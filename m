From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance tests
Date: Tue, 10 Jun 2003 16:36:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <00e001c32f90$016072c0$4a00000a@badass>
References: <20030610071638.R37090@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <ralph+d@istop.com>, "'David S. Miller'" <davem@redhat.com>,
   <fw@deneb.enyo.de>, <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jamal Hadi'" <hadi@shell.cyberus.ca>,
   "'Simon Kirby'" <sim@netnation.com>
In-Reply-To: <20030610071638.R37090@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'd be happy to set up a repository ftp site or maybe even some cvs
servers so all of us can test 
All these things and share data.  We are an ISP so it wouldn't be too
hard to just pop up another server
To store all this :>  Let me know 

Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: Jamal Hadi [mailto:hadi@shell.cyberus.ca] 
Sent: Tuesday, June 10, 2003 7:23 AM
To: Simon Kirby
Cc: ralph+d@istop.com; CIT/Paul; 'David S. Miller'; fw@deneb.enyo.de;
netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance tests




On Tue, 10 Jun 2003, Simon Kirby wrote:

[some good stuff deleted]

Simon,
I havent looked at your data in details; i will. Someone like Robert
would be able to snuff it much faster than i do. I just wanna say thanks
for the effort, I will spend time catching up with you folks. It is
clear that our next hurudle is gc. Do you have profiles for your data?
Profiles would be nice to collect as well.

> In any case, setting gc_min_interval to 0 definitely helped, but I 
> suspect Dave's patches will make a bigger difference.  Next up is 
> 2.5.70-bk14 and 2.5.70-bk14+davem's stuff from yesterday.
>

Also since you are doing all that work post the kernels somewhere so
people like foo can grab them and test as well.

cheers,
jamal
