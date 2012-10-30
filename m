From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next v4 0/7] Multiqueue support in tuntap
Date: Tue, 30 Oct 2012 16:52:49 -0700
Message-ID: <20121030165249.4cc4d596@nehalam.linuxnetplumber.net>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, maxk@qualcomm.com,
	haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351488964-11109-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am testing BQL for tuntap.
It wouldn't be hard to do BQL in the multi-queue version.
