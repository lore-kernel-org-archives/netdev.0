From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]net:switchdev:add judgement and proper return vlaue to
 make switchdev_port_vlan_fill() more robust
Date: Tue, 06 Dec 2016 09:32:46 -0500 (EST)
Message-ID: <20161206.093246.1063828677061160197.davem@davemloft.net>
References: <CAEX1niU24TLaRff+TMPu4ek4vT=R2mv9yaE6j1W1ZsFYh99QGg@mail.gmail.com>
        <20161206123225.GK1984@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxdx2006@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, feng.deng@cortina-access.com
To: jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161206123225.GK1984@nanopsycho>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 6 Dec 2016 13:32:25 +0100

> Tue, Dec 06, 2016 at 05:46:36AM CET, cxdx2006@gmail.com wrote:
>>From: Feng Deng<cxdx2006@gmail.com>
>>
>>1.add judgement to make sure switchdev_port_vlan_fill() could
>>  return right,  even when switchdev_port_vlan_dump_put() failed  ,
>>  which will make switchdev_port_vlan_fill()  more robust
>>2.add proper return vlaue at the end of the switchdev_port_vlan_fill()
>>
>>Signed-off-by: Feng Deng <feng.deng@cortina-access.com>
> 
> Please don't send patches like this. You are wasting everyone's time.

+1
