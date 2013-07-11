From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 08/50] USB: legousbtower: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 14:36:23 +0200
Message-ID: <3187374.nPY1jDDWKm@linux-5eaq.site>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com> <1373533573-12272-9-git-send-email-ming.lei@canonical.com> <51DEA289.5050509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Juergen Stuber <starblue@users.sourceforge.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <51DEA289.5050509@cogentembedded.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11 July 2013 16:18:17 Sergei Shtylyov wrote:

>     I don't think this patch passes checkpatch.pl.

This series is a mechanical replacement in dozens of drivers.
We cannot demand nice formatting. If you want to do something
productive, check the locking in the driver.

	Regards
		Oliver

