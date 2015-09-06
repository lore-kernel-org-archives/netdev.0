From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: bridge: check __vlan_vid_del for error
Date: Sun, 6 Sep 2015 08:32:30 +0200
Message-ID: <20150906063230.GB2141@nanopsycho.orion>
References: <1441502877-31972-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441502877-31972-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Sep 06, 2015 at 03:27:57AM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Since __vlan_del can return an error code, change its inner function
>__vlan_vid_del to return an eventual error from switchdev_port_obj_del.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
