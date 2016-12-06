From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH]net:switchdev:add judgement and proper return vlaue to
 make switchdev_port_vlan_fill() more robust
Date: Tue, 6 Dec 2016 13:32:25 +0100
Message-ID: <20161206123225.GK1984@nanopsycho>
References: <CAEX1niU24TLaRff+TMPu4ek4vT=R2mv9yaE6j1W1ZsFYh99QGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, feng.deng@cortina-access.com
To: Feng Deng <cxdx2006@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAEX1niU24TLaRff+TMPu4ek4vT=R2mv9yaE6j1W1ZsFYh99QGg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Dec 06, 2016 at 05:46:36AM CET, cxdx2006@gmail.com wrote:
>From: Feng Deng<cxdx2006@gmail.com>
>
>1.add judgement to make sure switchdev_port_vlan_fill() could
>  return right,  even when switchdev_port_vlan_dump_put() failed  ,
>  which will make switchdev_port_vlan_fill()  more robust
>2.add proper return vlaue at the end of the switchdev_port_vlan_fill()
>
>Signed-off-by: Feng Deng <feng.deng@cortina-access.com>

Please don't send patches like this. You are wasting everyone's time.

Thanks!
