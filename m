From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Thu, 9 Jan 2014 11:33:46 -0800
Message-ID: <CANJ5vP+5VVDNGR6OjmkWFNTNTiS=NKdkYEXxrkXRQ2uO+p=3xw@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<20140109014255.GA19321@redhat.com>
	<CANJ5vP+_aK0PMc6-hwbu6PduVNDe8jbWR19cN5C+k4mWQzdTGg@mail.gmail.com>
	<CANJ5vPLvDff5PMYNGvtt-dd=md8b46ZXAYLv-KnerNcfzDNHpw@mail.gmail.com>
	<20140109064807.GC19559@redhat.com>
	<CANJ5vPJp-AwvFDtY1R7SJg6L2dkEU6xPivgKcg4f0+05JCMEfw@mail.gmail.com>
	<20140109132529.GB2712@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140109132529.GB2712@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Michael,

Your improvements (code changes, more consistent naming, and use of
256-byte alignment only) all sound good to me. I will get started on a v3
patchset in conformance with your recommendations after sorting out
what we want to do with the debugfs/sysfs issues. I will followup soon on
the thread for patch 4/4 so we can close on what changes are needed for
debugfs/sysfs. Thanks!

Best,

Mike
