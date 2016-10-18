From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/10] mm: remove write/force parameters
 from __get_user_pages_unlocked()
Date: Tue, 18 Oct 2016 14:46:28 +0200
Message-ID: <20161018124628.GB29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-3-lstoakes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>,
 linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>,
 intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net,
 ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org,
 lin
To: Lorenzo Stoakes <lstoakes@gmail.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-3-lstoakes@gmail.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gVGh1IDEzLTEwLTE2IDAxOjIwOjEyLCBMb3JlbnpvIFN0b2FrZXMgd3JvdGU6Cj4gVGhpcyBw
YXRjaCByZW1vdmVzIHRoZSB3cml0ZSBhbmQgZm9yY2UgcGFyYW1ldGVycyBmcm9tCj4gX19nZXRf
dXNlcl9wYWdlc191bmxvY2tlZCgpIHRvIG1ha2UgdGhlIHVzZSBvZiBGT0xMX0ZPUkNFIGV4cGxp
Y2l0IGluIGNhbGxlcnMgYXMKPiB1c2Ugb2YgdGhpcyBmbGFnIGNhbiByZXN1bHQgaW4gc3VycHJp
c2luZyBiZWhhdmlvdXIgKGFuZCBoZW5jZSBidWdzKSB3aXRoaW4gdGhlCj4gbW0gc3Vic3lzdGVt
Lgo+IAo+IFNpZ25lZC1vZmYtYnk6IExvcmVuem8gU3RvYWtlcyA8bHN0b2FrZXNAZ21haWwuY29t
PgoKVGhlIHBhdGNoIGxvb2tzIGdvb2QuIFlvdSBjYW4gYWRkOgoKUmV2aWV3ZWQtYnk6IEphbiBL
YXJhIDxqYWNrQHN1c2UuY3o+CgoJCQkJCQkJCUhvbnphCi0tIApKYW4gS2FyYSA8amFja0BzdXNl
LmNvbT4KU1VTRSBMYWJzLCBDUgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVz
a3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9p
bnRlbC1nZngK
