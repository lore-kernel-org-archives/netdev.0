From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Mon, 14 Nov 2011 14:25:17 +0200
Message-ID: <CAOJsxLE4yRO+5XncrDEzVh5-RGXG+=HGTAmQ=bX=KMsDqf=feA@mail.gmail.com>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
	<20111113102428.GD15322@redhat.com>
	<1321196430.2425.2.camel@sasha>
	<4EC07729.3050303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sasha Levin <levinsasha928@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	mingo@elte.hu, gorcunov@gmail.com,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Asias He <asias.hejun@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4EC07729.3050303@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2011 at 4:04 AM, Asias He <asias.hejun@gmail.com> wrote:
> Why both the bandwidth and latency performance are dropping so dramatically
> with multiple VQ?

What's the expected benefit from multiple VQs i.e. why are doing the
patches Sasha?
