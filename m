From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'libertas' branch of wireless-2.6
Date: Wed, 30 May 2007 10:07:52 -0400
Message-ID: <465D8538.8070507@garzik.org>
References: <20070529183347.GD3496@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070529183347.GD3496-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Lots of stuff here...probably best for 2.6.23...

Is this best for Linux users... or just easy for developers?

Won't putting off all these fixes until 2.6.23 leave the driver released 
in 2.6.22 in shoddy shape?

libertas is upstream now, so we cannot pretend that the driver is 
completely independent from upstream release cycles and maintenance.

libertas fixes should go upstream immediately, since we are in a bugfix 
cycle, and since libertas (from upstream perspective) is about to make 
its big debut on the world stage.

	Jeff
