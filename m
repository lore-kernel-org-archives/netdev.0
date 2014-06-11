From: =?ISO-8859-15?Q?Egerv=E1ry_Gergely?= <gergely@egervary.hu>
Subject: Re: 3.4.92 MTU issues
Date: Wed, 11 Jun 2014 12:33:24 +0200
Message-ID: <53983074.6010800@egervary.hu>
References: <53975FF9.5070803@egervary.hu> <CAADnVQ+q3wFf=j0TY57d6Ux4GyGLr0bVCFHDgA45n9rXiEEzjg@mail.gmail.com> <20140610213722.GE1970@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@kernel.org
To: Florian Westphal <fw@strlen.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140610213722.GE1970@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -stable lacks commit 895162b1101b3ea5db08ca6822ae9672717efec0, so
> netfilter never sets ->local_df.  Thus all defragmented packets
> that go over the mtu are refused to be forwarded.

Thank you for your quick response. Should we expect a 3.4.93 release
with this issue fixed in a few days?

-- 
Gergely EGERVARY
Network Administrator
