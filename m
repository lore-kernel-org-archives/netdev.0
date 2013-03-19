From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Tue, 19 Mar 2013 05:59:58 -0700
Message-ID: <1363697998.21184.54.camel@edumazet-glaptop>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
	  <1363333305-54398-2-git-send-email-jasowang@redhat.com>
	  <1363399851.29475.52.camel@edumazet-glaptop>
	  <20130317.121318.1869489921021513474.davem@davemloft.net>
	  <51482F55.8020900@redhat.com> <1363695234.21184.36.camel@edumazet-glaptop>
	 <514860DC.9020404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514860DC.9020404@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-19 at 13:58 +0100, Daniel Borkmann wrote:

> Yes, will post them in a couple of minutes.
> 

Please target net tree for the first patch (adding thoff into struct
flow_keys), so that Jason or me can fix DODGY  providers.

Thanks
