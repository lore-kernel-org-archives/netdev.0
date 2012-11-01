From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next v4 0/7] Multiqueue support in tuntap
Date: Thu, 01 Nov 2012 13:07:40 +0800
Message-ID: <5092039C.60009@redhat.com>
References: <1351488964-11109-1-git-send-email-jasowang@redhat.com> <20121030165249.4cc4d596@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, maxk@qualcomm.com,
	haixiao@juniper.net, ernesto.martin@viasat.com,
	krkumar2@in.ibm.com, edumazet@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121030165249.4cc4d596@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/31/2012 07:52 AM, Stephen Hemminger wrote:
> I am testing BQL for tuntap.
> It wouldn't be hard to do BQL in the multi-queue version.

Yes, if BQL for tuntap is in first, I will rebase and convert it to 
multiqueue version.

Thanks
