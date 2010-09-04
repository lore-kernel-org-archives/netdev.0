From: Christian Riesch <christian.riesch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sat, 04 Sep 2010 19:48:02 +0200
Message-ID: <4C828652.4060804@gmail.com>
References: <cover.1283504065.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009041221240.888@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009041221240.888-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter wrote:
> On Fri, 3 Sep 2010, Richard Cochran wrote:
>> Recently on the lkml, we discussed how to allow adjustment of posix
>> clocks. I have tried to understand and implement the ideas expressed
>> in the various threads.
....
> Could you explain why the existing interfaces are not sufficient that do
> what you describe?

Richard's idea is to support clock hardware for IEEE 1588 (PTP, 
Precision Time Protocol). Have a look at the earlier discussions:

http://lkml.org/lkml/2010/8/16/90
and
http://lkml.org/lkml/2010/8/23/49

Christian
