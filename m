From: Ilya Dryomov <ilya.dryomov@inktank.com>
Subject: Re: [PATCH] net: ceph: armor.c: Remove unused function
Date: Sun, 21 Dec 2014 14:19:36 +0300
Message-ID: <CALFYKtC_mbeUPtJtLak+8KibDXB-M0VdOoFQxQ=ifpAeSNvhdw@mail.gmail.com>
References: <1419115000-12178-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419115000-12178-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 21, 2014 at 1:36 AM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Remove the function ceph_armor() that is not used anywhere.
>
> This was partially found by using a static code analysis program called cppcheck.

It's ceph_unarmor()'s counterpart - so same as for "[PATCH] net: ceph:
crypto.c: Remove some unused functions".

Thanks,

                Ilya
