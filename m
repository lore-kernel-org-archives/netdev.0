From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 8/8] treewide: Remove newlines inside
 DEFINE_PER_CPU() macros
Date: Mon, 7 Dec 2015 16:33:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE695F@AcuExch.aculab.com>
References: <1449242787-16598-1-git-send-email-mmarek@suse.com>
 <1449242787-16598-9-git-send-email-mmarek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Michal Marek' <mmarek@suse.com>,
	"linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449242787-16598-9-git-send-email-mmarek@suse.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Marek
> Sent: 04 December 2015 15:26
> Otherwise make tags can't parse them:
> 
> ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
...

Seems to me you need to fix ctags.

	David
