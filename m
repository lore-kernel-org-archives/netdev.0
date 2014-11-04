From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/20] selftests/net: move test out of Makefile into a
 shell script
Date: Tue, 04 Nov 2014 14:53:15 -0500 (EST)
Message-ID: <20141104.145315.548353349719796428.davem@davemloft.net>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
	<cover.1415117102.git.shuahkh@osg.samsung.com>
	<51d57725e89809806bd8af5555af341296cc4dd7.1415117102.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, keescook@chromium.org, tranmanphong@gmail.com,
	dh.herrmann@gmail.com, hughd@google.com, bobby.prani@gmail.com,
	ebiederm@xmission.com, serge.hallyn@ubuntu.com,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: shuahkh@osg.samsung.com
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <51d57725e89809806bd8af5555af341296cc4dd7.1415117102.git.shuahkh@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuahkh@osg.samsung.com>
Date: Tue,  4 Nov 2014 10:10:58 -0700

> Currently bpf test run from the Makefile. Move it out of the
> Makefile to be run from a shell script to allow the test to
> be run as stand-alone test, in addition to allowing the test
> run from a make target.
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>

Acked-by: David S. Miller <davem@davemloft.net>
