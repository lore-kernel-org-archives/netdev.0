From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/1] hv_sock: implements Hyper-V transport
 for Virtual Sockets (AF_VSOCK)
Date: Mon, 28 Aug 2017 15:38:52 -0700 (PDT)
Message-ID: <20170828.153852.1182668029079177666.davem@davemloft.net>
References: <PS1P15301MB00117CF517E0EFF548C9F572BF980@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhansen@vmware.com, stefanha@redhat.com, netdev@vger.kernel.org,
        mkubecek@suse.cz, olaf@aepfle.de, sthemmin@microsoft.com,
        rolf.neugebauer@docker.com, jasowang@redhat.com,
        dave.scott@docker.com, linux-kernel@vger.kernel.org,
        apw@canonical.com, marcelo.cerri@canonical.com,
        dan.carpenter@oracle.com, gregkh@linuxfoundation.org,
        joe@perches.com, devel@linuxdriverproject.org, vkuznets@redhat.com,
        haiyangz@microsoft.com, georgezhang@vmware.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <PS1P15301MB00117CF517E0EFF548C9F572BF980@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Sat, 26 Aug 2017 04:52:43 +0000

> 
> Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> mechanism between the host and the guest. It uses VMBus ringbuffer as the
> transportation layer.
> 
> With hv_sock, applications between the host (Windows 10, Windows Server
> 2016 or newer) and the guest can talk with each other using the traditional
> socket APIs.
> 
> More info about Hyper-V Sockets is available here:
> 
> "Make your own integration services":
> https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/make-integration-service
> 
> The patch implements the necessary support in Linux guest by introducing a new
> vsock transport for AF_VSOCK.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

Applied, thank you.
