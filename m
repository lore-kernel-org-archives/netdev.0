From: "David S. Miller" <davem@redhat.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Thu, 12 Sep 2002 16:34:47 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020912.163447.131926830.davem@redhat.com>
References: <3D80DF4F.5B218F19@mc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: borisp@mc.com
In-Reply-To: <3D80DF4F.5B218F19@mc.com>
List-Id: netdev.vger.kernel.org


Bonding does not help with single stream performance.
You have to have multiple apps generating multiple streams
of data before you'll realize any improvement.
Therefore netpipe is a bad test for what you're doing.
