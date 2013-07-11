From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 08/50] USB: legousbtower: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:47:03 +0400
Message-ID: <51DEB757.6070202@cogentembedded.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-9-git-send-email-ming.lei@canonical.com> <51DEA289.5050509@cogentembedded.com> <3187374.nPY1jDDWKm@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Juergen Stuber <starblue@users.sourceforge.net>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <3187374.nPY1jDDWKm@linux-5eaq.site>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11-07-2013 16:36, Oliver Neukum wrote:

>>      I don't think this patch passes checkpatch.pl.

> This series is a mechanical replacement in dozens of drivers.

    That mechanicity shows too much in some patches.

> We cannot demand nice formatting.  If you want to do something
> productive, check the locking in the driver.

    I'm not paid for it and don't have time to do it for free.

> 	Regards
> 		Oliver

WBR, Sergei


