From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] mlx4_en: Use correct loop cursor in error path.
Date: Thu, 30 Apr 2015 09:28:50 +0300
Message-ID: <CAPcc5PifqicmbSTpqfUUf+gF2eLxLLwT4EF-UYMdystmtPWX4w@mail.gmail.com>
References: <1430348375-9077-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430348375-9077-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 30, 2015 at 1:59 AM, Benjamin Poirier <bpoirier@suse.de> wrote:
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Fixes: 9e311e7 ("net/mlx4_en: Use affinity hint")
> ---

Good catch.

Acked-by: Amir Vadai <amirv@mellanox.com>

Thanks,
Amir
